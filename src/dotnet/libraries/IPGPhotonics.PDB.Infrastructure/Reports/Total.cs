using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Total")]
    internal sealed class Total : Base
        {
        protected internal override String ClassName { get { return "Total"; }}
        [UsedImplicitly][Field] public String EvaluateCondition { get; }
        [UsedImplicitly][Field] public String Expression { get; }
        [UsedImplicitly][Field] public String Evaluator { get; }
        [UsedImplicitly][Field] public String PrintOn { get; }
        [UsedImplicitly][Field] public Boolean IncludeInvisibleRows { get; }
        [UsedImplicitly][Field] public Boolean ResetAfterPrint { get; } = true;
        [UsedImplicitly][Field] public Boolean ResetOnReprint { get; } = true;
        [UsedImplicitly][Field] public TotalType TotalType { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }
