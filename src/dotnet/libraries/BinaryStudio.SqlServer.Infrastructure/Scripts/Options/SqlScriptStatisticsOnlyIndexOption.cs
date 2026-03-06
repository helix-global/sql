using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlStatisticsOnlyIndexOption))]
    internal sealed class SqlScriptStatisticsOnlyIndexOption : SqlScriptIndexOption<SqlStatisticsOnlyIndexOption>
        {
        public SqlOnOffValue OnOffValue { get { return Source.OnOffValue; }}
        public Int32 Value { get { return Source.Value; }}

        #region ctor{IServiceProvider,SqlStatisticsOnlyIndexOption}
        public SqlScriptStatisticsOnlyIndexOption(IServiceProvider context,SqlStatisticsOnlyIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }