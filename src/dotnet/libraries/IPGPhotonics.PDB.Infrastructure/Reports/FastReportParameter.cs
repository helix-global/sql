using System;
using System.Collections.Generic;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Parameter")]
    public class FastReportParameter : FastReportObject
        {
        [UsedImplicitly][Field] public String Name { get; }
        [UsedImplicitly][Field] public String DataType { get; }
        }
    }
