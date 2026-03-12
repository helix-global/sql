using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(VectorMetricIndexOption))]
    internal sealed class SqlFragmentVectorMetricIndexOption : SqlFragmentIndexOption<VectorMetricIndexOption>
        {
        #region ctor{IServiceProvider,VectorMetricIndexOption}
        public SqlFragmentVectorMetricIndexOption(IServiceProvider context,VectorMetricIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }