package stat

import atn.Branch
import basemain.Cid
import chribase_thread.CuteThread
import cpt.*
import libmain.BranchSendsUserItsBrad
import libmain.TransportSingleConceptIbr
import libmain._pp_

/** Stat container */
object mainStat: StatModule() {

    object test1Stat: F(14_338) { override fun func(br: Branch) {
        println("in test1Stat()")
    }}

    /**
     *      Send branch address of the current branch to user.
     */
    object sendUserBranchBrad: FCid(19_223) {

        /**
         *  @param br current branch
         *  @param userThread_premCid Cid of the premise, containing the user thread object reference.
        */
        override fun func(br: Branch, userThread_premCid: Cid) {
        val userThread = (br[userThread_premCid] as CuteThreadPrem).thread as CuteThread
        userThread.putInQueue(BranchSendsUserItsBrad(br.ownBrad.clone()))
    }}

    /**
     *      Send branch address of the current branch to user.
     *
     *  Note1: the container is filled in with its load - the string premise, cid of which is specified in the spirit part
     *  of the container, in the get() function of the branch, when the live concepts are created.
     *
     *  Note2: this functor takes care of switchin activation for the container premise. On sending the activation of the sent
     *      copy is set to 1 and activation of the remaining is set to -1. So on the receiver side it will mean that the request
     *      is active and requires processing, and on our side request is fulfilled and deactivated. The string premise inside
     *      the container will be anactivated on both sides.
     */
    object requestUserInputLine: F2Cid(47_628) {

        /**
         *  @param br current branch
         *  @param containerCid This concept contains the userInputLine_strprem premise, which will be holding
         *          actual user line.
         */
        override fun func(br: Branch, destBridCid: Cid, containerCid: Cid) {
            val destBrad = (br[destBridCid] as Branch).ownBrad
            val remainingContainer = (br[containerCid] as ConceptPrem)
            (remainingContainer.cpt as StringPrem).anactivate()     // anactivate load
            remainingContainer.anactivate()                         // anactivate remaining container
            val outgoingContainer = remainingContainer.clone() as ConceptPrem
            outgoingContainer.activate()                            // activate outgoing container
            _pp_.putInQueue(TransportSingleConceptIbr(destBrad, outgoingContainer, br.ownBrad))
        }
    }

    object test4Stat: FLCid(4) {
        override fun func(br: Branch, vararg cids: Cid) {

        }
    }
}   //     43_137 72_493 53_148 51_211 50_023 62_408 89_866 24_107
