using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("SubreportObject")]
    internal sealed class SubreportObject : ReportComponentBase
        {
        protected internal override String ClassName { get { return "SubreportObject"; }}
        [UsedImplicitly][Field] public Boolean PrintOnParent { get; }
        [UsedImplicitly][Field] public String ReportPage { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }
