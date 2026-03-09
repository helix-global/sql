using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlStatisticsNoRecomputeIndexOption))]
    internal sealed class SqlScriptStatisticsNoRecomputeIndexOption : SqlScriptOnOffIndexOption<SqlStatisticsNoRecomputeIndexOption>
        {
        #region ctor{IServiceProvider,SqlStatisticsNoRecomputeIndexOption}
        public SqlScriptStatisticsNoRecomputeIndexOption(IServiceProvider context,SqlStatisticsNoRecomputeIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }