using System;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class FastReportBandColumns : FastReportObject
        {
        [UsedImplicitly][Field] public Int32 Count { get; }
        [UsedImplicitly][Field] public Int32 MinRowCount { get; }
        [UsedImplicitly][Field] public ColumnLayout Layout { get; }
        [UsedImplicitly][Field(ConverterCulture="en-US")] public Single Width { get; }

        #region M:Serialize(XmlWriter,String)
        public override void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,prefix);
            }
        #endregion
        }
    }