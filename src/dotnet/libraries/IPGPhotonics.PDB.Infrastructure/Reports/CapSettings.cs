using System;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class CapSettings : FastReportObject
        {
        [UsedImplicitly][Field(ConverterCulture="en-US")] public Single Height { get; } = 8f;
        [UsedImplicitly][Field(ConverterCulture="en-US")] public Single Width { get; } = 8f;
        [UsedImplicitly][Field] public CapStyle Style { get; }

        #region M:Serialize(XmlWriter,String)
        public override void Serialize(XmlWriter writer,String prefix) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,this,prefix);
            }
        #endregion
        }
    }