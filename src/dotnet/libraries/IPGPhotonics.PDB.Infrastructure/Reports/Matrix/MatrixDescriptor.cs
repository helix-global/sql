using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class MatrixDescriptor : FastReportObject
        {
        [UsedImplicitly][Field(Order=1000200)] public String Expression { get; }
        }
    }