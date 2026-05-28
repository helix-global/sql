using System;
using System.Collections.Generic;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public abstract class MatrixDescriptor : FastReportObject
        {
        [UsedImplicitly][Field] public String Expression { get; }
        }
    }