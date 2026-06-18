using System;
using System.Collections.Generic;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [TypeConverter(typeof(SqlObjectConverter<FastReportPageColumns>))]
    internal sealed class FastReportPageColumns : FastReportObject,IEquatable<FastReportPageColumns>,IFastReportClassObject
        {
        String IFastReportClassObject.ClassName { get { return "PageColumns"; }}
        [UsedImplicitly][Field(Order=1000101)][DefaultValue(1)] public Int32 Count { get; } = 1;
        [UsedImplicitly][Field(Order=1000103,Converter=typeof(SqlSingleCollectionConverter))] public IList<Single> Positions { get; } = EmptyArray<Single>.List;
        [UsedImplicitly][Field(Order=1000102,ConverterCulture="en-US")] public Single Width { get; }

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        #region M:Equals(Object):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(Object other) {
            if (ReferenceEquals(other,null)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return Equals(other as FastReportPageColumns);
            }
        #endregion
        #region M:Equals(FastReportPageColumns):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(FastReportPageColumns other) {
            if (ReferenceEquals(other,null)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return (Count == other.Count)
                && (Width == other.Width)
                && SqlSingleCollectionConverter.Equals(Positions,other.Positions);
            }
        #endregion
        #region M:GetHashCode:Int32
        /// <summary>Calculates a hash code for the current object.</summary>
        /// <returns>Returns a hash code for the current object.</returns>
        public override Int32 GetHashCode() {
            return
                HashCodeCombiner.GetHashCode(
                HashCodeCombiner.GetHashCode(Positions),
                Count,Width);
            }
        #endregion
        }
    }