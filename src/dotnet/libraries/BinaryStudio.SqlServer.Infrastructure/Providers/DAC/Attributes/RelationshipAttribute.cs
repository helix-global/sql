using System;
using System.ComponentModel;
using System.Globalization;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [AttributeUsage(AttributeTargets.Property,AllowMultiple = false)]
    internal class RelationshipAttribute : Attribute,ISqlModelMappingAttribute
        {
        public String Source { get;set; }
        public Multiplicity Multiplicity { get; }
        public RelationshipKind Kind { get;set; } = RelationshipKind.Auto;

        #region ctor
        public RelationshipAttribute() {
            Multiplicity = new Multiplicity(0,UnlimitedNatural.Unlimited);
            }
        #endregion
        #region ctor{String}
        public RelationshipAttribute(String multiplicity) {
            Multiplicity = new Multiplicity(multiplicity);
            }
        #endregion
        #region ctor{String,RelationshipKind}
        public RelationshipAttribute(String multiplicity,RelationshipKind kind)
            :this(multiplicity)
            {
            Kind = kind;
            }
        #endregion
        }

    [Flags]
    internal enum RelationshipKind
        {
        Auto,
        Element    = 1,
        Reference  = 2,
        Annotation = 4
        }

    internal class RelationshipConverter : TypeConverter
        {
        #region M:ConvertFrom(ITypeDescriptorContext,CultureInfo,Object):Object
        /// <summary>Converts the given object to the type of this converter, using the specified context and culture information.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="culture">The <see cref="T:System.Globalization.CultureInfo"/> to use as the current culture.</param>
        /// <param name="value">The <see cref="T:System.Object"/> to convert.</param>
        /// <returns>An <see cref="T:System.Object"/> that represents the converted value.</returns>
        /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
        public override Object ConvertFrom(ITypeDescriptorContext context,CultureInfo culture,Object value) {
            if ((value == null) || (value is DBNull)) { return null; }
            return base.ConvertFrom(context,culture,value);
            }
        #endregion
        }
    }
