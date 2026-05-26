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

    public abstract class StyleBase : FastReportObject
        {
        [UsedImplicitly][Field] public Boolean ApplyBorder { get; }
        [UsedImplicitly][Field] public Boolean ApplyFill { get; }
        [UsedImplicitly][Field] public Boolean ApplyFont { get; }
        [UsedImplicitly][Field] public Boolean ApplyTextFill { get; }
        [UsedImplicitly][Field] public String Font { get; }
        }
    }