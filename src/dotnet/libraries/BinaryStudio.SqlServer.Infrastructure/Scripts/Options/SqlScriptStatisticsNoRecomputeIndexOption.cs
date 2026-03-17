using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlStatisticsNoRecomputeIndexOption))]
    internal sealed class SqlScriptStatisticsNoRecomputeIndexOption : SqlScriptOnOffIndexOption<SqlStatisticsNoRecomputeIndexOption>
        {
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.StatisticsNoRecompute; }}

        #region ctor{IServiceProvider,SqlStatisticsNoRecomputeIndexOption}
        public SqlScriptStatisticsNoRecomputeIndexOption(IServiceProvider context,SqlStatisticsNoRecomputeIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }