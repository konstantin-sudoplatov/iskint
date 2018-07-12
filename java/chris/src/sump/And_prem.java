package sump;

import chris.Crash;
import chris.Glob;
import concepts.Concept;
import concepts.dyn.primitives.Set_prim;
import java.util.List;
import concepts.dyn.ifaces.GetActivationIface;

/**
 * Set of cids, all of them must be active for this premise to be active. No calculation of the activation value is needed, activation
 * is calculated dynamically in the get_activation() method. That method also actualizes the green count - counter of the antiactive
 * members.
 * @author su
 */
public class And_prem extends Set_prim implements GetActivationIface {

    //---***---***---***---***---***--- public classes ---***---***---***---***---***---***

    //---***---***---***---***---***--- public data ---***---***---***---***---***--

    /** 
     * Constructor.
     */ 
    public And_prem() { 
    } 

    //^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v
    //
    //                                  Public methods
    //
    //v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^

    /**
     * Decrement counter of antiactive premises. That counter allows to avoid unnecessary checks on the premise.
     * @return new value of the counter.
     */
    public int decrement_green_count() {
        if (greenCount <=0)
            throw new Crash(String.format("greenCount = %s, but it must be positive.", greenCount));
        
        greenCount--;
        if (greenCount == 0 )
            activatioN = 1;
        
        return greenCount;
    }
    
    @Override
    public boolean add_member(Concept cpt) {
        boolean r = super.add_member(cpt);
        if (r) {
            calculate_activation();
            return true;
        }
        else
            return false;
    }

    @Override
    public boolean remove_member(Concept cpt) {
        
        boolean r = super.remove_member(cpt);
        if (r) {
            calculate_activation();
            return true;
        }
        else
            return false;
    }

    @Override
    public NormalizationType get_normalization_type() {
        return NormalizationType.BIN;
    }
   
    @Override
    public float get_activation() {
        return activatioN;
    }

    /**
     * Sets the activation value to the logical production of the activations of members.
     * @return calculated activation value.
     */
    public float calculate_activation() {
        activatioN = 1;
        greenCount = 0;
        for (Long cid: get_members()) {
            GetActivationIface cpt = (GetActivationIface)this.get_name_space().load_cpt(cid);
            if      // is it an antiactive concept?
                    (cpt.get_activation() <= 0)
            {   // our activation will be antiactive also
                activatioN = -1;
                greenCount++;
            }
        }
        
        return activatioN;
    }

    /**
     * Create list of lines, which shows the object's content. For debugging. Invoked from Glob.print().
     * @param note printed in the first line just after the object type.
     * @param debugLevel 0 - the shortest, 2 - the fullest
     * @return list of lines, describing this object.
     */
    @Override
    public List<String> to_list_of_lines(String note, Integer debugLevel) {
        List<String> lst = super.to_list_of_lines(note, debugLevel);
        Glob.append_last_line(lst, String.format("activatioN = %s", activatioN));

        return lst;
    }

    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%
    //
    //      Private    Private    Private    Private    Private    Private    Private
    //
    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%

    //---%%%---%%%---%%%---%%%---%%% private data %%%---%%%---%%%---%%%---%%%---%%%---%%%
    
    /** Activation.  */
    private float activatioN = -1;
    
    /** Count of antiactive members. */
    private int greenCount;

    //---%%%---%%%---%%%---%%%---%%% private methods ---%%%---%%%---%%%---%%%---%%%---%%%--
}
