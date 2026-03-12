using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlFragmentIndexStateOption<T> : SqlFragmentIndexOption<T>
        where T : IndexStateOption
        {
        #region ctor{IServiceProvider,T}
        protected SqlFragmentIndexStateOption(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        public override String ToString()
            {
            return $"{Phrase.ToLowerInvariant()} = {Source.OptionState.ToString().ToLowerInvariant()}";
            }
        #endregion
        }

    [SqlScriptObject(typeof(IndexStateOption))]
    internal sealed class SqlFragmentIndexStateOption : SqlFragmentIndexStateOption<IndexStateOption>
        {
        #region ctor{IServiceProvider,IndexStateOption}
        public SqlFragmentIndexStateOption(IServiceProvider context,IndexStateOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }