using System.Collections.Generic;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("MatrixObject")]
    internal class MatrixObject : TableBase
        {
        [UsedImplicitly][Field(EmptyIfNull = true,Source="MatrixColumns")] public IList<MatrixHeaderDescriptor> Columns { get; }
        [UsedImplicitly][Field(EmptyIfNull = true,Source="MatrixRows")]    public IList<MatrixHeaderDescriptor> Rows { get; }
        [UsedImplicitly][Field(EmptyIfNull = true,Source="MatrixCells")]   public IList<MatrixCellDescriptor>   Cells { get; }
        }
    }
