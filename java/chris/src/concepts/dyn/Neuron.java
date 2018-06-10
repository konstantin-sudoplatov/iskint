package concepts.dyn;

import attention.CaldronLoop;
import chris.Glob;
import concepts.*;
import java.util.Arrays;

/**
 * It is a concept capable of reasoning, i.e. calculating activation as the weighted sum of premises.
 * The same way it determines successors and their activations. 
 * @author su
 */
public class Neuron extends DynamicConcept implements AssertionIface, ActionIface, EffectIface, PropertyIface, PremiseIface {
    
    /** Structure of premises. A pair of weight of a concept and its cid. */
    public static class Premise {
        public float weight;    // Weight with which this cid takes part in the weighted sum.
        public long cid;
        public Premise(float weight, long cid) {
            this.weight = weight;
            this.cid = cid;
        }
    }

    /**
     * Default constructor.
     */
    public Neuron() {
    }

//    /**
//     * Constructor
//     * @param props array of cids of concept properties. 
//     */
//    public Neuron(long[] props) {
//        this.propertieS = props;
//    }
    
    //^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v
    //
    //                                  Public methods
    //
    //v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^

    @Override
    public Neuron clone() {
        Neuron clon = (Neuron)super.clone();
        if (actionS != null) clon.actionS = Arrays.copyOf(actionS, actionS.length);
        if (propertieS != null) clon.propertieS = Arrays.copyOf(propertieS, propertieS.length);
        if (effectS != null) clon.effectS = Arrays.copyOf(effectS, effectS.length);
        if (premiseS != null) clon.premiseS = Arrays.copyOf(premiseS, premiseS.length);
        
        return clon;
    }
    
    @Override
    public long[] assertion(CaldronLoop context) {
        throw new UnsupportedOperationException("Not realized yet");
    }
//
//    /**
//     * Getter.
//     * @return
//     */
//    public long[] get_action_cid() {
//        return actionS;
//    }
//
//    /**
//     * Setter.
//     * @param actionCid
//     */
//    public void set_action_cid(long[] actionCid) {
//        this.actionS = actionCid;
//    }

    @Override
    public long get_action(int index) {
        return actionS[index];
    }

    @Override
    public long[] get_actions() {
        return actionS;
    }

    @Override
    public long add_action(long cid) {
        actionS = Glob.append_array(actionS, cid);
        return cid;
    }

    @Override
    public void set_actions(long[] actionArray) {
        actionS = actionArray;
    }

    @Override
    public long get_effect(int index) {
        return effectS[index];
    }

    @Override
    public long[] get_effects() {
        return effectS;
    }

    @Override
    public long add_effect(long cid) {
        effectS = Glob.append_array(effectS, cid);
        return cid;
    }

    @Override
    public void set_effects(long[] propArray) {
        effectS = propArray;
    }

    @Override
    public long get_property(int index) {
        return propertieS[index];
    }

    @Override
    public long[] get_properties() {
        return propertieS;
    }

    @Override
    public long add_property(long cid) {
        propertieS = Glob.append_array(propertieS, cid);
        return cid;
    }

    @Override
    public void set_properties(long[] propArray) {
        propertieS = propArray;
    }

    @Override
    public Premise get_premise(int index) {
        return premiseS[index];
    }

    @Override
    public Premise[] get_premises() {
        return premiseS;
    }

    @Override
    public Premise add_premise(Premise premise) {
        premiseS = (Premise[])Glob.append_array(premiseS, premise);
        return premise;
    }

    @Override
    public void set_premises(Premise[] premiseArray) {
        premiseS = premiseArray;
    }

    public float get_bias() {
        return biaS;
    }

    public void set_bias(float bias) {
        biaS = bias;
    }
            
    
    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%
    //
    //      Private    Private    Private    Private    Private    Private    Private
    //
    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%

    //---%%%---%%%---%%%---%%%---%%% private data %%%---%%%---%%%---%%%---%%%---%%%---%%%
    
    /** Array of actions. */
    private long[] actionS;
    
    /** Array of possible effects. */
    private long[] effectS;
    
    /** Array of cids, defining pertinent data . The cids are not forbidden to be duplicated in the premises. */
    private long[] propertieS;
    
    /** Array of cids and weights of premises. The cids are not forbidden to be duplicated in the properties. */
    private Premise[] premiseS;
    
    /** The free term of the linear expression. */
    private float biaS;
    
    //---%%%---%%%---%%%---%%%---%%% private methods ---%%%---%%%---%%%---%%%---%%%---%%%--

    //---%%%---%%%---%%%---%%%---%%% private classes ---%%%---%%%---%%%---%%%---%%%---%%%--
}
