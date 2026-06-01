using System;
using System.ComponentModel;
using System.Windows;
using System.Windows.Forms;
using System.Windows.Media;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("Sort")]
    internal sealed class Sort : FastReportObject
        {
        [UsedImplicitly][Field] public Boolean Descending { get; }
        [UsedImplicitly][Field] public String Expression { get; }
        }
    }