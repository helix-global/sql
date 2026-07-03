using System;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [UsedImplicitly]
    [FastReportClass("MsSqlDataConnection")]
    internal sealed class FastReportDataConnection : FastReportDataConnectionBase
        {
        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }