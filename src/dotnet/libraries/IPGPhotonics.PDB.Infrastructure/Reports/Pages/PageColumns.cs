using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Printing;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public class PageColumns : FastReportObject
        {
        [UsedImplicitly][Field] public Int32 Count { get; } = 1;
        [UsedImplicitly][Field(Converter=typeof(SqlSingleCollectionConverter))] public IList<Single> Positions { get; }
        [UsedImplicitly][Field] public Single Width { get; }
        }
    }