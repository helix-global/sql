using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;
using System;
using System.ComponentModel;
using System.Windows.Forms;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class ComponentBase : Base
        {
        [UsedImplicitly][Field(Order=1000201)] public Single Left { get; }
        [UsedImplicitly][Field(Order=1000202)] public Single Top { get; }
        [UsedImplicitly][Field(Order=1000203)] public Single Width { get; }
        [UsedImplicitly][Field(Order=1000204)] public Single Height { get; }
        [UsedImplicitly][Field(Order=1000206,Converter=typeof(SqlEnumConverter<AnchorStyles>))][DefaultValue(AnchorStyles.Left|AnchorStyles.Top)] public AnchorStyles Anchor { get; } = AnchorStyles.Left|AnchorStyles.Top;
        [UsedImplicitly][Field(Order=1000205,Converter=typeof(SqlEnumConverter<DockStyle>))] public DockStyle Dock { get; }
        [UsedImplicitly][Field(Order=1000207)][DefaultValue(true)] public Boolean Visible { get; } = true;
        [UsedImplicitly][Field(Order=1000208)] public Int32 GroupIndex { get; }
        }
    }
