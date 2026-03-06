using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlFillFactorIndexOption))]
    internal sealed class SqlScriptFillFactorIndexOption : SqlScriptIndexOption<SqlFillFactorIndexOption>
        {
        [UsedImplicitly][Field] public Int32 FillFactor { get; }

        #region ctor{IServiceProvider,SqlFillFactorIndexOption}
        public SqlScriptFillFactorIndexOption(IServiceProvider context,SqlFillFactorIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }