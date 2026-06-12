using System;
using System.ComponentModel;
using System.Drawing;
using System.Globalization;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [TypeConverter(typeof(SqlObjectConverter<SolidFill>))]
    internal sealed class SolidFill : FillBase,IEquatable<SolidFill>,IEquatable<Color>,IEquatable<KnownColor>
        {
        [UsedImplicitly][Field(Converter=typeof(FastReportColorConverter))] public Color Color { get; }

        #region ctor
        public SolidFill()
            :this(Color.Transparent)
            {
            }
        #endregion
        #region ctor{Color}
        public SolidFill(Color color)
            {
            Color = color;
            }
        #endregion

        #region M:Equals(Object):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(Object other) {
            if (other is Color)      { return Equals((Color)other);      }
            if (other is KnownColor) { return Equals((KnownColor)other); }
            return Equals(other as SolidFill);
            }
        #endregion
        #region M:Equals(SolidFill):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(SolidFill other) {
            return (other != null)
                && (Color == other.Color);
            }
        #endregion
        #region M:Equals(Color):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(Color other) {
            return (Color == other);
            }
        #endregion
        #region M:Equals(KnownColor):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(KnownColor other) {
            return (Color.ToKnownColor() == other);
            }
        #endregion
        #region M:Equals(FillBase):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(FillBase other) {
            if (other == null) { return false; }
            if (ReferenceEquals(this, other)) { return true; }
            return Equals(other as SolidFill);
            }
        #endregion
        #region M:GetHashCode():Int32
        /// <summary>Calculates a hash code for the current object.</summary>
        /// <returns>A hash code for the current object.</returns>
        public override Int32 GetHashCode()
            {
            return HashCodeCombiner.GetHashCode(Color);
            }
        #endregion
        #region M:ToString:String
        public override String ToString()
            {
            return $"{FillConverter.Instance.ConvertToInvariantString(this)}:Color={Color}";
            }
        #endregion
        #region M:CoerceValue(PropertyDescriptor,Object,CultureInfo):Object
        protected override Object CoerceValue(PropertyDescriptor descriptor,Object value,CultureInfo culture) {
            if (descriptor.Name == nameof(Color)) {
                color = value;
                }
            return base.CoerceValue(descriptor, value, culture);
            }
        #endregion
        #region M:SerializeAttribute(XmlWriter,String,PropertyDescriptor)
        protected override void SerializeAttribute(XmlWriter writer,String prefix,PropertyDescriptor descriptor) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            if (descriptor == null) { throw new ArgumentNullException(nameof(descriptor)); }
            if (descriptor.Name == nameof(Color)) {
                writer.WriteAttributeString($"{prefix}.{descriptor.Name}",color?.ToString());
                return;
                }
            base.SerializeAttribute(writer,prefix,descriptor);
            }
        #endregion

        private Object color;
        }
    }