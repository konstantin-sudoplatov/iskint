package atn

import basemain.*
import chribase_thread.CuteThread
import cpt.*
import cpt.abs.Action
import cpt.abs.DynamicConcept
import cpt.abs.Neuron
import cpt.abs.SpiritDynamicConcept
import libmain.*
import kotlin.math.max

/**
 *      All reasoning takes place in this class. All brans are packed in pods and those in the pod pool.
 *  Parent-child relationships of the brans has nothing to do with parent-child relationships of the threads(pods). Pods
 *  are children of the main branch, where they are started. Branches are born, live and terminate in their own logical
 *  hierarchy.
 *
 *  No sharing, no synchronization, all work takes place in one thread.
 *
 *  @param breedCid Cid of the breed concept for the branch.
 *  @param ownBrad Brad object, that identifies its place in the pod pool and pod.
 *  @param parentBrad parent's ownBrad. Can be null if it's root.
 */
open class Branch(
    val breedCid: Cid,
    val ownBrad: Brad,          // own address
    private val parentBrad: Brad?,      // parent's address
    val dlv: Int = 0            // branch debug level. There is also thread debug level and GLOBAL_DEBUG_LEVEL.
) {

    /**
     *      It is a heart of the system. In here we calculate activation of a current neuron (the stem) and take decision
     *  what acts should be done, which brans spawned, and which neuron will become our next stem or should we yield
     *  the flow control and wait until conditions change and the next call comes.
     */
    fun reasoning() {
        var stem = stem_
        dlog {ar(
            "enter, stem = ${stem.toStr()}",
            "enter, stem = $stem"
        )}

        // Main reasoning cycle
        while(true) {

            // Do the neuron's assessment and determine effect
            val eff = stem.calculateActivationAndSelectEffect(this)

            // Do acts, if any
            if(eff.actions != null)
                for(actCid in eff.actions)
                    (this[actCid] as Action).run(this)

            // Spawn brans, if any
            if(eff.branches != null)
                for(destBreedCid in eff.branches) {

                    // Form an array of cloned from the current branch ins for the destination branch
                    val insCids = (_sm_[destBreedCid] as SpBreed).ins
                    val clonedIns = if(insCids != null) Array(insCids.size)
                        { this[insCids[it]].clone() as DynamicConcept} else null

                    _pp_.putInQueue(BranchRequestsPodpoolCreateChildMsg(destBreedCid, destIns = clonedIns, parentBrad = ownBrad))
                }

            // Assign new stem or yield
            if(eff.stemCid != 0)
                stem = this[eff.stemCid] as Neuron
            else
                break
        }

        // Save stem and exit
        stem_ = stem
        dlog {ar(
            "exit, stem_ = ${stem.toStr()}",
            "exit, stem_ = $stem"
        )}
    }

    /**
     *      Add concept to live map bypassing the spirit map. Used for concept injections.
     *  @param cpt live dynamic concept
     */
    fun add(cpt: DynamicConcept) {
        liveMap_[cpt.cid] = cpt
    }

    /**
     *          Get live concept from local map. If not present, create and set it up.
     */
    operator fun get(cid: Cid): DynamicConcept {

        var cpt = liveMap_[cid]
        when {
            cpt != null -> return cpt
            else -> {   // Create and setup live concept
                cpt = (_sm_[cid] as SpiritDynamicConcept).liveFactory()
                liveMap_[cid] = cpt

                // May be additional setup is needed
                when(cpt) {

                    // Load the string premise
                    is ConceptPrem -> {
                        val strCptCid = (cpt.sp as SpConceptPrem).cptCid
                        val strCpt = liveMap_[strCptCid]?: (_sm_[strCptCid] as SpiritDynamicConcept).liveFactory()
                        liveMap_[strCptCid] = strCpt
                        cpt.cpt = strCpt
                    }
                }
                return cpt
            }
        }
    }

    /**
     *      Add a child branch to the list of children.
     *  @param childBrad
     */
    fun addChild(childBrad: Brad) {
        children.add(childBrad)
    }

    /**
     *      Log a debugging line. The debug level is taken as a maximum of the global, thread or branch debug level. The lambda
     *  provides an array of lines, corresponding to the debug levels, where the first array element corresponds to the
     *  level 1. If there is no corresponding line, than the last line of the array is used. If the line is empty, nothing
     *  is logged.
     *  @param lines Lamba, resulting in ar array of strings, one of which will be logged.
     */
    inline fun dlog(lines: () -> Array<String>) {
        if (DEBUG_ON) {
            val pod = ownBrad.pod
            val effectiveLvl = max(max(GLOBAL_DEBUG_LEVEL, pod.dlv), this.dlv)
            if(effectiveLvl <= 0) return
            if      // is there a line corresponding to the debug level?
                    (effectiveLvl <= lines().size)
            {   //yes: log that line
                if(lines()[effectiveLvl-1] != "") logit("%s, %s: %s".format(pod.podName, branchName(), lines()[effectiveLvl-1]))
            }
            else //no: log the last line of the array
                if(lines()[lines().lastIndex] != "") logit("%s, %s: %s".format(pod.podName, branchName(), lines()[lines().lastIndex]))
        }
    }

    fun branchName(): String {
        var s = if(DEBUG_ON) _nm_!![breedCid]?: "noname" else this::class.qualifiedName?: ""
        if(s == "hardCid.circle_breed")
            s = "circle"
        else
            s = s.replace(".breed", "")

        return s
    }

    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%
    //
    //                               Private
    //
    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%

    //---%%%---%%%---%%%---%%%--- private data ---%%%---%%%---%%%---%%%---%%%---%%%

    /** Branch-local map of live concepts */
    private val liveMap_ = hashMapOf<Cid, DynamicConcept>()

    /** The head neuron of the branch. Initially it's the seed from the breed concept. */
    private var stem_: Neuron = this[(this[breedCid].sp as SpBreed).seedCid] as Neuron

    /** List of child brans. Used to send them the termination message. */
    private val children = ArrayList<Brad>()

    /**
     *      Main constructor.
     */
    init {
        // Set up the breed
        @Suppress("LeakingThis")
        val breed = this[breedCid] as Breed
        breed.brad = ownBrad
        breed.activate()
    }
}

/**
 *      Attention circle. It is the root branch for all the branch tree that communicates with userThread.
 *  @param breedCid Cid of the breed concept for the branch.
 *  @param brad Brad object, that identifies its place in the pod and pod pool.
 *  @param userThread User thread.
 */
class AttentionCircle(breedCid: Cid, brad: Brad, userThread: CuteThread): Branch(breedCid, brad, null) {
    init {

        // Inject the userThread_prem hard cid premise
        val userThreadPrem = this[hardCrank.hardCid.userThread_prem.cid] as CuteThreadPrem
        userThreadPrem.thread = userThread
        userThreadPrem.activate()
    }
}