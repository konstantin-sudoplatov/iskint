package concepts;

/**
 *  Static concepts identifiers.
 * Concept identifiers are named after the corresponding classes. ordinal() is used as a numerical concept Id in ComDir. Also used for
 * automated generation of the static concept objects pointed by ComDir.
 * @author su
 */
public enum StatCptEnum {
    Mark_Marker,
    Mark_Identifier,
    Mark_Type,
    ;
    
    /** Is used to find static concept classes in ComDir.generate_static_concepts(). Must be the same as the package containing
      those classes. Remember when refactoring! */
    public static final String STATIC_CONCEPTS_PACKET_NAME = "concepts.stat";   // 
}
