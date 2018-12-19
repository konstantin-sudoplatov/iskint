package cpt.abs

import basemain.Cid
import basemain.Cvr

/**
 *      Base class for all concepts.
 *  "Spiritual" means stable and storable as opposed to the "Live" concepts, that are in a constant use, changing and live
 *  only in memory. All live concepts contain reference to its spirit counterparts.
 *  @param cid Concept identifier. If 0, then the spirit map will assign it a real one.
*/
abstract class SpiritConcept(cid: Cid) {

    /** Concept identifier */
    val cid: Cid = cid

    /** Version number */
    var ver: Cvr = 0

    /**
        Create "live" wrapper for this object.
    */
    abstract fun live_factory(): Concept;
}

/**
 *      Live wrapper for the SpiritConcept.
 *  The spiritConcept concepts contain stable data. In fact all branches consider them immutable. Their live mates in contrast
 *  operate with changeable data, like activation or prerequisites. While the spiritConcept concepts are shared by all caldrons,
 *  the live ones are referenced only in their own branches.
 *
 *  We don't create live concepts directly through constructors, instead we use the live_factory() method of their
 *  holy partners.
 *
 *  @param spiritConcept
*/
abstract class Concept(spiritConcept: SpiritConcept): Cloneable {

    /** Spiritual part */
    val sp = spiritConcept

    override public fun clone(): Any {
        return super.clone()
    }

    override fun toString(): String {
        var s = this::class.simpleName as String
        s += "\nsp = $sp".replace("\n", "\n    ")
        return s
    }
}

/**
 *       Base for all spirit dynamic concepts.
 *
 *  @param cid
*/
abstract class SpiritDynamicConcept(cid: Cid): SpiritConcept(cid) {

}

/**
 *      Base for live dynamic concepts.
 *
 *  @param spiritDynamicConcept
 */
abstract class DynamicConcept(spiritDynamicConcept: SpiritDynamicConcept): Concept(spiritDynamicConcept) {

}