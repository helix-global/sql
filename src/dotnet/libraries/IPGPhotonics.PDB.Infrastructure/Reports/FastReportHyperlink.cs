using System;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class FastReportHyperlink : FastReportObject
        {
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
        }
    }