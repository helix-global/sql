using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptDomConstraintDefinition<T> : SqlScriptDomObject<T>,ISqlScriptConstraint
        where T : ConstraintDefinition
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptDomConstraintDefinition(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }