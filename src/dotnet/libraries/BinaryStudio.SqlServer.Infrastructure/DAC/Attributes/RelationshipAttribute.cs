using System;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [AttributeUsage(AttributeTargets.Property,AllowMultiple = false)]
    internal class RelationshipAttribute : Attribute,ISqlModelMappingAttribute
        {
        public String SourceName { get;set; }
        public Multiplicity Multiplicity { get; }
        public RelationshipAttribute(String multiplicity) {
            Multiplicity = new Multiplicity(multiplicity);
            }
        public RelationshipAttribute() {
            Multiplicity = new Multiplicity(0,UnlimitedNatural.Unlimited);
            }
        }
    }
