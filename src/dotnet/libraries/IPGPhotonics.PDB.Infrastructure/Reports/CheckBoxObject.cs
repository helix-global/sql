using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("CheckBoxObject")]
    internal sealed class CheckBoxObject : ReportComponentBase
        {
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color CheckColor { get; }
        [UsedImplicitly][Field] public Boolean Checked { get; } = true;
        [UsedImplicitly][Field] public Boolean HideIfUnchecked { get; }
        [UsedImplicitly][Field] public CheckedSymbol CheckedSymbol { get; }
        [UsedImplicitly][Field] public UncheckedSymbol UncheckedSymbol { get; }
        [UsedImplicitly][Field] public Single CheckWidthRatio { get; } = 1f;
        [UsedImplicitly][Field] public String DataColumn { get; }
        [UsedImplicitly][Field] public String Expression { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }
