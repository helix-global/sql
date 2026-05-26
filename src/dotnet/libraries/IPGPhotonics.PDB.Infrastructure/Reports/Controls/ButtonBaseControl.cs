using System;
using System.Drawing;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public class ButtonBaseControl : DataFilterBaseControl
        {
        [UsedImplicitly][Field] public Boolean AutoSize { get; }
        [UsedImplicitly][Field] public ContentAlignment TextAlign { get; }
        [UsedImplicitly][Field] public TextImageRelation TextImageRelation { get; }
        }
    }