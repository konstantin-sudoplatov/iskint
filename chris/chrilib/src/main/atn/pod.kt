package atn

import basemain.*
import chribase_thread.CuteThread
import chribase_thread.MessageMsg
import chribase_thread.TerminationRequestMsg
import chribase_thread.TimeoutMsg
import libmain.*
import java.util.*
import kotlin.Comparator
import kotlin.random.Random

/**
 *      Full address of branch in the pod pool
 *  @param pod pod object
 *  @param brid branch identifier in pod. It is an integer key in the branch map the pod object.
 */
data class Brid(val pod: Pod, val brid: Int)

/**
 *      This is a thread, that contains a number of branches.
 *  @param podName Alias for threadName
 *  @param pid Pod identifier. It is the index of the pod in the pool's array of pods
 */
class Pod(podName: String, val pid: Int): CuteThread(POD_THREAD_QUEUE_TIMEOUT, MAX_POD_THREAD_QUEUE, podName)
{
    /** Alias for threadName */
    val podName: String
        inline get() = threadName

    /** Number of branches currently assigned to the pod. */
    internal var numOfBranches = 0

    override fun toString(): String {
        var s= super.toString()
        s += "\n    numOfBranches = $numOfBranches"
        s += "\n    pid = $pid"
        return s
    }

    //~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$
    //
    //                                  Protected
    //
    //~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$

    //---$$$---$$$---$$$---$$$---$$$ protected data ---$$$---$$$---$$$---$$$---$$$--

    //---$$$---$$$---$$$---$$$---$$$--- protected methods ---$$$---$$$---$$$---$$$---$$$---

    override fun _messageProc(msg: MessageMsg): Boolean {

        when(msg) {

            is UserTellsCircleIbr -> {
                // todo: give it to circle
                return true
            }

            is UserRequestsDispatcherCreateAttentionCircleMsg -> {
                val circle = AttentionCircle()
                val brid = generateBrid()
                branchMap[brid] = circle
                numOfBranches++
                _pp_.putInQueue(AttentionCircleReportsPodpoolDispatcherUserItsCreation(msg.user, Brid(this, brid)))

                return true
            }

            is TerminationRequestMsg -> {
                return true
            }

            is TimeoutMsg ->
                if      //is this pod idle?
                        (numOfBranches == 0)
                    //yes: it's ok, silence the timeout
                    return true
                else {
                    // todo: give it to circle
                    return false
                }
        }
        return false
    }

    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%
    //
    //                               Private
    //
    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%

    //---%%%---%%%---%%%---%%%--- private data ---%%%---%%%---%%%---%%%---%%%---%%%

    /** Map Branch/bridObj. */
    private val branchMap = hashMapOf<Int, Branch>()

    //---%%%---%%%---%%%---%%%--- private funcs ---%%%---%%%---%%%---%%%---%%%---%%%

    private fun generateBrid(): Int {

        var brid: Int
        do {
            brid = Random.nextInt(Int.MIN_VALUE, Int.MAX_VALUE)
        } while(brid in branchMap)

        return brid
    }
}

/**
 *      Comparator for pods is needed for building sorted set of pods (TreeSet<Pod>).
 */
class PodComparator: Comparator<Pod>
{
    override fun compare(o1: Pod?, o2: Pod?): Int {
        assert(value = o1 != null && o2 != null)

        if
                (o1!!.numOfBranches != o2!!.numOfBranches)
            return if(o1.numOfBranches < o2.numOfBranches) -1 else 1
        else
            if
                    (o1.pid != o2.pid)
                return if(o1.pid < o2.pid) -1 else 1
            else
                return 0
    }
}

/**
 *      Pool of pods. It is of fixed size and populated with running pods (they are started on the pool construction).
 *  @param size number of pods in the pool
 */
class Podpool(val size: Int = POD_POOL_SIZE): CuteThread(0, 0, "pod_pool")
{
    override fun _messageProc(msg: MessageMsg?): Boolean {
        when(msg) {

            is UserRequestsDispatcherCreateAttentionCircleMsg -> {

                // Take from podSet the pod with smallest usage, so preventing it from dispatching before it will be
                // loaded with new branch. It will be returned back on getting report on starting the branch in the
                // correspondent handler.
                if      //are all of the pods busy with dispatching new branches?
                        (podSet.isEmpty())
                {   //yes: do spin-blocking - sleep for a short wile then redispatch the message
                    assert(borrowedPodNum == podArray.size)
                    if (!podpoolOverflowReported) {
                        logit("no free pods to create a branch")    // log the overflow without flooding
                        podpoolOverflowReported = true
                    }
                    Thread.sleep(1)
                    putInQueue(msg)

                    return true
                }
                else
                {   //no: take out a pod from the pod set and request pod to create new attention circle

                    val pod = podSet.pollFirst()
                    borrowedPodNum++
                    pod.putInQueue(msg)     // forward message to pod

                    return true
                }
            }

            is AttentionCircleReportsPodpoolDispatcherUserItsCreation -> {

                podSet.add(msg.bridObj.pod)
                podpoolOverflowReported = false
                borrowedPodNum--
                _atnDispatcher_.putInQueue(msg)

                return true
            }

            is TerminationRequestMsg -> {

                // Terminate pods
                for(pod in podArray)
                    pod.putInQueue(msg)

                return true
            }
        }

        return false
    }

    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%
    //
    //                               Private
    //
    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%

    //---%%%---%%%---%%%---%%%--- private data ---%%%---%%%---%%%---%%%---%%%---%%%

    // Create and start all pods
    private var podArray: Array<Pod> = Array<Pod>(size, {Pod("pod_$it", it).also {it.start()}})

    /** Sorted set of pods. Pods are sorted by their usage number, plus a unique id to avoid repetition. */
    private val podSet = TreeSet<Pod>(PodComparator())

    /** Number of pods currently creating new branches. */
    private var borrowedPodNum: Int = 0

    /** To avoid flooding the log. */
    private var podpoolOverflowReported = false

    init {
        // Register all pods in the tree set
        for(pod in podArray) podSet.add(pod)
    }
}