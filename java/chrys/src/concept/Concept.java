package concept;

/**
 * Base class for all concepts.
 * @author su
 */
public class Concept {
    //##################################################################################################################
    //                                              Public types        
    public enum Lineage {
        /** Hard-coded concept as opposed to dynamically generated one.*/
        STATIC,
        /** Dynamically generated as opposed to hard-coded one. */
        DYNAMIC
    }
    
    //##################################################################################################################
    //                                              Public data

    //##################################################################################################################
    //                                              Constructors

    //##################################################################################################################
    //                                              Public methods

    public long getCid() {
        return cid;
    }

    public void setCid(long cid) {
        this.cid = cid;
    }

    //##################################################################################################################
    //                                              Protected data

    //##################################################################################################################
    //                                              Protected data
    /** Concept Id. Initialized by an illegal ID to show it is not yet generated. */
    private long cid = -1;

    //##################################################################################################################
    //                                              Private methods, data
}
