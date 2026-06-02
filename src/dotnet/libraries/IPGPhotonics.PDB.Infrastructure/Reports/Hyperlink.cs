using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class Hyperlink : FastReportObject
        {
        [UsedImplicitly][Field] public String DetailPageName { get; }
        [UsedImplicitly][Field] public String DetailReportName { get; }
        [UsedImplicitly][Field] public String Expression { get; }
        [UsedImplicitly][Field] public String ReportParameter { get; }
        [UsedImplicitly][Field] public String Value { get; }
        [UsedImplicitly][Field] public String ValuesSeparator { get; }
        [UsedImplicitly][Field] public HyperlinkKind Kind { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }