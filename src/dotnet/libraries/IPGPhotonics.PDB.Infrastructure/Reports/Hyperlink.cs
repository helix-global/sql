using System;
using System.ComponentModel;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class Hyperlink : FastReportObject
        {
        [UsedImplicitly][Field(Order=1000105)] public String DetailPageName { get; }
        [UsedImplicitly][Field(Order=1000104)] public String DetailReportName { get; }
        [UsedImplicitly][Field(Order=1000102)] public String Expression { get; }
        [UsedImplicitly][Field(Order=1000106)] public String ReportParameter { get; }
        [UsedImplicitly][Field(Order=1000103)] public String Value { get; }
        [UsedImplicitly][Field(Order=1000107)] public String ValuesSeparator { get; }
        [UsedImplicitly][Field(Order=1000101)] public HyperlinkKind Kind { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
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