using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlStatisticsIncrementalIndexOption))]
    internal sealed class SqlScriptStatisticsIncrementalIndexOption : SqlScriptOnOffIndexOption<SqlStatisticsIncrementalIndexOption>
        {
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.StatisticsIncremental; }}

        #region ctor{IServiceProvider,SqlStatisticsIncrementalIndexOption}
        public SqlScriptStatisticsIncrementalIndexOption(IServiceProvider context,SqlStatisticsIncrementalIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }