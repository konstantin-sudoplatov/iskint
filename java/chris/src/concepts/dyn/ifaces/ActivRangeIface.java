package concepts.dyn.ifaces;

import auxiliary.Effects;
import concepts.dyn.Action;
import concepts.dyn.Neuron;

/**
 * Getters and setters for the array of activation ranges.
 * @author su
 */
public interface ActivRangeIface {

    /**
     * Get arrays of action and ways cids, corresponding to the given activation value.
     * @param activation activation value
     * @return effect structure. It can consists of nulls or empty arrays but cannot be null itself.
     * @throws Crash() for uninitialized action selector or for nonexistent range.
     */
    public Effects select_effects(float activation);
    
    /**
     * Add new element to the activation ranges array. The new boundary must be less or equal to the last existing boundary. One boundary
     * cannot be repeated more than twice.
     * @param lowerBoundary this boundary delimits the range from the last existing boundary including to this value excluding.
     * @param actions array of action cids
     * @param ways array of way cids
     */
    public void add_effects(float lowerBoundary, long[] actions, long[] ways);

    /** 
     * Ditto.
     * @param lowerBoundary
     * @param action single action concept
     * @param way single way neuron
     */
    public void add_effects(float lowerBoundary, Action action, Neuron way);

    /** 
     * Ditto.
     * @param lowerBoundary
     * @param actions array of action cids
     * @param way single way neuron
     */
    public void add_effects(float lowerBoundary, long[] actions, Neuron way);

    /** 
     * Ditto.
     * @param lowerBoundary
     * @param action single action concept
     * 
     * @param ways array of way cids
     */
    public void add_effects(float lowerBoundary, Action action, long[] ways);

}
