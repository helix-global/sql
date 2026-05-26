using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("GridControl")]
    internal class GridControl : DialogControl
        {
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<GridControlColumn> Columns { get; }
        }
    }
