using System;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class HatchFill : FillBase,IEquatable<HatchFill>
        {
        [UsedImplicitly][Field(Order=1000102,Converter=typeof(FastReportColorConverter))][DefaultValue(KnownColor.White)] public Color BackColor { get; } = Color.White;
        [UsedImplicitly][Field(Order=1000101,Converter=typeof(FastReportColorConverter))][DefaultValue(KnownColor.Black)] public Color ForeColor { get; } = Color.Black;
        [UsedImplicitly][Field(Order=1000103,Converter=typeof(SqlEnumConverter<HatchStyle>))] public HatchStyle Style { get; }

        #region M:Equals(HatchFill):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(HatchFill other) {
            return (other != null)
                && (BackColor == other.BackColor)
                && (ForeColor == other.ForeColor)
                && (Style == other.Style);
            }
        #endregion
        #region M:Equals(FillBase):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(FillBase other) {
            if (other == null) { return false; }
            if (ReferenceEquals(this, other)) { return true; }
            return Equals(other as HatchFill);
            }
        #endregion
        }
    }