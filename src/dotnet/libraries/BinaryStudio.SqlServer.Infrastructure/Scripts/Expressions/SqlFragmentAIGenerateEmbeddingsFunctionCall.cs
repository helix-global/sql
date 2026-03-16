using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(AIGenerateEmbeddingsFunctionCall))]
    internal sealed class SqlFragmentAIGenerateEmbeddingsFunctionCall : SqlFragmentPrimaryExpression<AIGenerateEmbeddingsFunctionCall>
        {
        #region ctor{IServiceProvider,AIGenerateEmbeddingsFunctionCall}
        public SqlFragmentAIGenerateEmbeddingsFunctionCall(IServiceProvider context,AIGenerateEmbeddingsFunctionCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }