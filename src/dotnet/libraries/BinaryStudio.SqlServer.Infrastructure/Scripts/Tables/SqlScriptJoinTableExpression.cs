using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptJoinTableExpression<T> : SqlScriptTableExpression<T>
        where T: SqlJoinTableExpression
        {
        public SqlJoinOperatorType JoinOperator {get{ return Source.JoinOperator; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptJoinTableExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }