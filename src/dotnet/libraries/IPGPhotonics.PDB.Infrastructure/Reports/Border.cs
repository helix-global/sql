using System;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class Border : FastReportObject
        {
        [UsedImplicitly][Field] public BorderLines Lines { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color Color
            {
            get { return LeftLine.Color; }
            set
                {
                BottomLine.Color = value;
                LeftLine.Color   = value;
                RightLine.Color  = value;
                TopLine.Color    = value;
                }
            }

        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color ShadowColor { get; }
        [UsedImplicitly][Field] public Boolean Shadow { get; }
        [UsedImplicitly][Field] public Boolean SimpleBorder { get; }
        [UsedImplicitly][Field] public Single ShadowWidth { get; } = 4f;

        [UsedImplicitly][Field] public Single Width
            {
            get { return LeftLine.Width; }
            set
                {
                BottomLine.Width = value;
                LeftLine.Width   = value;
                RightLine.Width  = value;
                TopLine.Width    = value;
                }
            }

        [UsedImplicitly][Field] public LineStyle Style
            {
            get { return LeftLine.Style; }
            set
                {
                BottomLine.Style = value;
                LeftLine.Style   = value;
                RightLine.Style  = value;
                TopLine.Style    = value;
                }
            }

        [UsedImplicitly][Field] public BorderLine BottomLine { get; } = new BorderLine();
        [UsedImplicitly][Field] public BorderLine LeftLine   { get; } = new BorderLine();
        [UsedImplicitly][Field] public BorderLine RightLine  { get; } = new BorderLine();
        [UsedImplicitly][Field] public BorderLine TopLine    { get; } = new BorderLine();
        }
    }