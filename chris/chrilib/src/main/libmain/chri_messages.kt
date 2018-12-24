package libmain

import atn.Brid
import chribase_thread.CuteThread
import chribase_thread.MessageMsg

class ReaderSendsConsoleLineMsg(val text: String): MessageMsg()

class CirclePromptsUserMsg(): MessageMsg()

class UserRequestsDispatcherCreateAttentionCircleMsg(val user: CuteThread): MessageMsg()

class AttentionCircleReportsPodpoolDispatcherUserItsCreation(val user: CuteThread, val brid: Brid): MessageMsg()

class CircleSendsUserItsBridMsg(val circleBrid: Brid): MessageMsg()

/**
 *      Base for messages addressed to pods (inter branch messages)
 *  @param destBridInd branch pid of the destination branch in the pod
 */
abstract class PodIbr(val destBridInd: Int): MessageMsg()

class UserTellsCircleIbr(destBridInd: Int, val text: String): PodIbr(destBridInd)