using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(VectorMetricIndexOption))]
    internal sealed class SqlScriptDomVectorMetricIndexOption : SqlScriptDomIndexOption<VectorMetricIndexOption>
        {
        #region ctor{IServiceProvider,VectorMetricIndexOption}
        public SqlScriptDomVectorMetricIndexOption(IServiceProvider context,VectorMetricIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }