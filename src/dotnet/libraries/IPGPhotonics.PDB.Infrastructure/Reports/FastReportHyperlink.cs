using System;
using System.ComponentModel;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [TypeConverter(typeof(SqlObjectConverter<FastReportHyperlink>))]
    internal sealed class FastReportHyperlink : FastReportObject,IFastReportClassObject,IEquatable<FastReportHyperlink>
        {
        String IFastReportClassObject.ClassName { get { return "Hyperlink"; } }
        [UsedImplicitly][Field(Order=1000105)] public String DetailPageName { get; }
        [UsedImplicitly][Field(Order=1000104)] public String DetailReportName { get; }
        [UsedImplicitly][Field(Order=1000102)] public String Expression { get; }
        [UsedImplicitly][Field(Order=1000106)] public String ReportParameter { get; }
        [UsedImplicitly][Field(Order=1000103)] public String Value { get; }
        [UsedImplicitly][Field(Order=1000107)] public String ValuesSeparator { get; }
        [UsedImplicitly][Field(Order=1000101)] public HyperlinkKind Kind { get; }

        #region M:Serialize(XmlWriter,String,Object)
        public override void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,prefix);
            }
        #endregion
        #region M:Equals(Object):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(Object other) {
            if (ReferenceEquals(other,null)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return Equals(other as FastReportHyperlink);
            }
        #endregion
        #region M:Equals(FastReportHyperlink):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(FastReportHyperlink other) {
            if (ReferenceEquals(other,null)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return (Kind==other.Kind)
                && String.Equals(DetailPageName,other.DetailPageName)
                && String.Equals(DetailReportName,other.DetailReportName)
                && String.Equals(Expression,other.Expression)
                && String.Equals(ReportParameter,other.ReportParameter)
                && String.Equals(Value,other.Value)
                && String.Equals(ValuesSeparator,other.ValuesSeparator);
            }
        #endregion
        #region M:GetHashCode:Int32
        /// <summary>Calculates a hash code for the current object.</summary>
        /// <returns>Returns a hash code for the current object.</returns>
        public override Int32 GetHashCode() {
            return HashCodeCombiner.GetHashCode(
                Kind,DetailPageName,DetailReportName,
                Expression,ReportParameter,Value,
                ValuesSeparator);
            }
        #endregion
        }
    }