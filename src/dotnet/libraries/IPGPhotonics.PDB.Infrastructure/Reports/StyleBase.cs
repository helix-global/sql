using System;
using System.ComponentModel;
using System.Windows;
using System.Windows.Forms;
using System.Windows.Media;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;
using Color = System.Drawing.Color;

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
        [UsedImplicitly][Field] public FillBase Fill { get; } = new SolidFill(Color.Transparent);
        [UsedImplicitly][Field] public FillBase TextFill { get; } = new SolidFill(Color.Black);
        [UsedImplicitly][Field] public Border Border { get; } = new Border();
        }
    }