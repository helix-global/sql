using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("RichObject")]
    internal sealed class FastReportRichObject : FastReportTextObjectBase
        {
        [UsedImplicitly][Field(Order=1000601)] public Int32 ActualTextStart { get; }
        [UsedImplicitly][Field(Order=1000602)] public Int32 ActualTextLength { get; }
        [UsedImplicitly][Field(Order=1000603)] public String DataColumn { get; }
        [UsedImplicitly][Field(Order=1000604)] public Boolean OldBreakStyle { get; }

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }
