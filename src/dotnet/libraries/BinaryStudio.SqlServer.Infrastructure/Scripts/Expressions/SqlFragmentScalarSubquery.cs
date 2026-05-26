using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(ScalarSubquery))]
    internal sealed class SqlFragmentScalarSubquery : SqlFragmentPrimaryExpression<ScalarSubquery>
        {
        #region ctor{IServiceProvider,ScalarSubquery}
        public SqlFragmentScalarSubquery(IServiceProvider context,ScalarSubquery source)
            : base(context,source)
            {
            }
        #endregion
        }
    }