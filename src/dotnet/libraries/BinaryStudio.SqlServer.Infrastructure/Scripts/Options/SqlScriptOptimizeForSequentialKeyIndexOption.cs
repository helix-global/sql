using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlOptimizeForSequentialKeyIndexOption))]
    internal sealed class SqlScriptOptimizeForSequentialKeyIndexOption : SqlScriptOnOffIndexOption<SqlOptimizeForSequentialKeyIndexOption>
        {
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.OptimizeForSequentialKey; }}

        #region ctor{IServiceProvider,SqlOptimizeForSequentialKeyIndexOption}
        public SqlScriptOptimizeForSequentialKeyIndexOption(IServiceProvider context,SqlOptimizeForSequentialKeyIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }