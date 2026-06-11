using System;
using System.ComponentModel;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class CapSettings : FastReportObject
        {
        [UsedImplicitly][Field(Order=1000102,ConverterCulture="en-US")][DefaultValue(8f)] public Single Height { get; } = 8f;
        [UsedImplicitly][Field(Order=1000101,ConverterCulture="en-US")][DefaultValue(8f)] public Single Width { get; } = 8f;
        [UsedImplicitly][Field(Order=1000103)] public CapStyle Style { get; }

        #region M:Serialize(XmlWriter,String,Object)
        public override void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,prefix);
            }
        #endregion
        }
    }