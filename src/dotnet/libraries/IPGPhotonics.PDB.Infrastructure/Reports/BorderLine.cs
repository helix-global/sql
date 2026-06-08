using System;
using System.ComponentModel;
using System.Drawing;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class BorderLine : FastReportObject,IEquatable<BorderLine>
        {
        [UsedImplicitly][Field(Converter=typeof(FastReportColorConverter))] public Color Color { get;set; }
        [UsedImplicitly][Field] public LineStyle Style { get;set; }
        [UsedImplicitly][Field(ConverterCulture="en-US")][DefaultValue(1f)] public Single Width { get;set; } = 1f;

        #region M:Equals(Object):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(Object other)
            {
            return Equals(other as BorderLine);
            }
        #endregion
        #region M:Equals(BorderLine):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(BorderLine other) {
            return (other != null)
                && (Width == other.Width)
                && (Color == other.Color)
                && (Style == other.Style);
            }
        #endregion
        #region M:GetHashCode():Int32
        /// <summary>Calculates a hash code for the current object.</summary>
        /// <returns>A hash code for the current object.</returns>
        public override Int32 GetHashCode()
            {
            return HashCodeCombiner.GetHashCode(Width,Color,Style);
            }
        #endregion
        #region M:Serialize(XmlWriter,String)
        public override void Serialize(XmlWriter writer,String prefix) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,this,prefix);
            }
        #endregion
        }
    }