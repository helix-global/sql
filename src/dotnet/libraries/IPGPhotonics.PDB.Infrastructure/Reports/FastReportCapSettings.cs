using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class FastReportCapSettings : FastReportObject
        {
        [UsedImplicitly][Field(Order=1000102,ConverterCulture="en-US")][DefaultValue(8f)] public Single Height { get; } = 8f;
        [UsedImplicitly][Field(Order=1000101,ConverterCulture="en-US")][DefaultValue(8f)] public Single Width { get; } = 8f;
        [UsedImplicitly][Field(Order=1000103)] public CapStyle Style { get; }

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }