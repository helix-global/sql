using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlFragmentCaseExpression<T> : SqlFragmentPrimaryExpression<T>
        where T: CaseExpression
        {
        #region ctor{IServiceProvider,T}
        public SqlFragmentCaseExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }