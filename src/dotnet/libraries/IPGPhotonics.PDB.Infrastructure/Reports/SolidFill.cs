using System;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class SolidFill : FillBase,IEquatable<SolidFill>,IEquatable<Color>,IEquatable<KnownColor>
        {
        protected internal override String ClassName { get { return "SolidFill"; }}
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color Color { get; }

        public SolidFill(Color color)
            {
            Color = color;
            }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
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
        #region M:GetHashCode():Int32
        /// <summary>Calculates a hash code for the current object.</summary>
        /// <returns>A hash code for the current object.</returns>
        public override Int32 GetHashCode()
            {
            return HashCodeCombiner.GetHashCode(Color);
            }
        #endregion
        }
    }